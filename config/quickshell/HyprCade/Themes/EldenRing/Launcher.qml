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

    Palette {
        id: colors
    }


    // ============================================================
    // OPEN / CLOSE
    // ============================================================

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


    // ============================================================
    // ACTIONS
    // ============================================================

    function openMusic(): void {
        const apps = DesktopEntries.applications.values

        for (let i = 0; i < apps.length; ++i) {
            const name =
            (apps[i].name || "").toLowerCase()

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
            const name =
            (apps[i].name || "").toLowerCase()

            if (name.includes("spotify")) {
                apps[i].execute()
                return
            }
        }
    }

    function backendTag(app): string {
        const id =
        (app.id || "").toLowerCase()

        const exec =
        (app.execString || "").toLowerCase()

        if (
            id.includes("flatpak")
            || exec.includes("flatpak")
            || id.includes("com.valvesoftware.steam")
        ) {
            return "FLATPAK"
        }

        return "NATIVE"
    }

    function searchTitle(app): string {
        const name =
        (app.name || "").toUpperCase()

        const lower =
        (app.name || "").toLowerCase()

        if (lower.includes("steam")) {
            return name
            + "  //  "
            + root.backendTag(app)
        }

        return name
    }

    function searchSubtitle(app): string {
        if (
            app.genericName
            && app.genericName.length > 0
        ) {
            return app.genericName.toUpperCase()
        }

        if (
            app.comment
            && app.comment.length > 0
        ) {
            return app.comment.toUpperCase()
        }

        return (
            app.id || "APPLICATION"
        ).toUpperCase()
    }


    // ============================================================
    // QUICK ACTIONS
    // ============================================================

    readonly property var quickActions: [
        {
            label: "TERMINAL",
            sub: "A passage to the command line.",
            symbol: "✦",
            command: "kitty",
            action: "command"
        },
        {
            label: "FILES",
            sub: "Browse thy stored possessions.",
            symbol: "◇",
            command: "dolphin",
            action: "command"
        },
        {
            label: "BROWSER",
            sub: "Traverse the distant network.",
            symbol: "◉",
            command: "zen-browser",
            action: "command"
        },
        {
            label: "MUSIC",
            sub: "Listen to echoes from afar.",
            symbol: "♪",
            command: "",
            action: "music"
        },
        {
            label: "LOCK",
            sub: "Let this place fall silent.",
            symbol: "⊕",
            command: "",
            action: "lock"
        },
        {
            label: "HYPRCADE",
            sub: "Shape the world itself.",
            symbol: "✧",
            command: "",
            action: "control"
        }
    ]


    // ============================================================
    // IPC
    // ============================================================

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


    Timer {
        id: hideTimer

        interval: 240

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }


    // ============================================================
    // SEARCH
    // ============================================================

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


    // ============================================================
    // WINDOW
    // ============================================================

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
                bottom: 18
                left: 0
            }

            implicitWidth: 336

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


            // ====================================================
            // MAIN PANEL
            // ====================================================

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 318

                x:
                root.opened
                ? 12
                : -320

                Behavior on x {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                color: colors.background

                border.width: 1
                border.color: colors.border


                // subtle inner frame
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5

                    color: "transparent"

                    border.width: 1
                    border.color: colors.panelAlt

                    opacity: 0.75
                }


                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 24
                        bottomMargin: 20
                        leftMargin: 22
                        rightMargin: 22
                    }

                    spacing: 0


                    // ============================================
                    // SITE OF GRACE HEADER
                    // ============================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "✦"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 26
                        }

                        Column {
                            Layout.leftMargin: 6

                            spacing: 0

                            Text {
                                text: "SITE OF GRACE"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 16
                                font.bold: true
                                font.letterSpacing: 1.4
                            }

                            Text {
                                text: "THE LANDS BETWEEN"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 1.1
                            }
                        }
                    }


                    Text {
                        Layout.topMargin: 10

                        text:
                        "Rest, Tarnished. Choose thy path."

                        color: colors.text

                        font.family: "serif"
                        font.pixelSize: 9
                        font.italic: true
                    }


                    Rectangle {
                        Layout.fillWidth: true

                        Layout.topMargin: 16
                        Layout.bottomMargin: 14

                        height: 1

                        color: colors.border
                    }


                    // ============================================
                    // SEARCH
                    // ============================================

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 14

                        height: 40

                        color: colors.panel

                        border.width: 1

                        border.color:
                        searchInput.activeFocus
                        ? colors.yellow
                        : colors.border


                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 12
                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: "⌕"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 14
                        }


                        TextInput {
                            id: searchInput

                            anchors {
                                left: parent.left
                                leftMargin: 32

                                right: parent.right
                                rightMargin: 12

                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: root.searchText

                            onTextChanged: {
                                root.searchText = text
                                menuList.currentIndex = 0
                            }

                            color: colors.text

                            selectionColor:
                            colors.yellow

                            selectedTextColor:
                            colors.background

                            font.family: "serif"
                            font.pixelSize: 10

                            clip: true


                            Keys.onPressed:
                            function(event) {

                                if (
                                    event.key
                                    === Qt.Key_Down
                                ) {
                                    if (menuList.count > 0) {
                                        menuList.currentIndex =
                                        (
                                            menuList.currentIndex
                                            + 1
                                        )
                                        % menuList.count

                                        menuList
                                        .positionViewAtIndex(
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
                                    if (menuList.count > 0) {
                                        menuList.currentIndex =
                                        (
                                            menuList.currentIndex
                                            - 1
                                            + menuList.count
                                        )
                                        % menuList.count

                                        menuList
                                        .positionViewAtIndex(
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
                                    if (menuList.currentItem)
                                        menuList.currentItem
                                        .activate()

                                        event.accepted = true
                                }
                            }

                            Keys.onEscapePressed:
                            root.closeLauncher()
                        }


                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 32

                                verticalCenter:
                                parent.verticalCenter
                            }

                            visible:
                            searchInput.text.length === 0

                            text: "SEARCH THE LANDS..."

                            color: colors.muted

                            font.family: "serif"
                            font.pixelSize: 9
                            font.letterSpacing: 0.5
                        }
                    }


                    // ============================================
                    // MENU
                    // ============================================

                    ListView {
                        id: menuList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 4
                        clip: true

                        model:
                        root.searchText.trim().length > 0
                        ? appSearchModel
                        : root.quickActions


                        delegate: Rectangle {
                            id: menuEntry

                            required property var modelData

                            property bool searchResult:
                            root.searchText.trim()
                            .length > 0

                            property bool keyboardSelected:
                            ListView.isCurrentItem

                            property bool highlighted:
                            keyboardSelected
                            || entryMouse.containsMouse

                            width: menuList.width
                            height: 60

                            color:
                            highlighted
                            ? colors.panelAlt
                            : "transparent"

                            border.width:
                            highlighted
                            ? 1
                            : 0

                            border.color:
                            colors.yellow


                            // grace marker
                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 9

                                    verticalCenter:
                                    parent.verticalCenter
                                }

                                text:
                                menuEntry.highlighted
                                ? "✦"
                                : "·"

                                color:
                                menuEntry.highlighted
                                ? colors.yellow
                                : colors.muted

                                font.family: "serif"

                                font.pixelSize:
                                menuEntry.highlighted
                                ? 14
                                : 12
                            }


                            Column {
                                anchors {
                                    left: parent.left
                                    leftMargin: 31

                                    right: parent.right
                                    rightMargin: 10

                                    verticalCenter:
                                    parent.verticalCenter
                                }

                                spacing: 3


                                Text {
                                    text:
                                    menuEntry.searchResult
                                    ? root.searchTitle(
                                        modelData
                                    )
                                    : modelData.label

                                    color:
                                    menuEntry.highlighted
                                    ? colors.yellow
                                    : colors.text

                                    font.family: "serif"
                                    font.pixelSize: 12
                                    font.bold:
                                    menuEntry.highlighted

                                    font.letterSpacing: 0.7
                                }


                                Text {
                                    width: parent.width

                                    text:
                                    menuEntry.searchResult
                                    ? root.searchSubtitle(
                                        modelData
                                    )
                                    : modelData.sub

                                    color: colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 8
                                    font.italic: true

                                    elide:
                                    Text.ElideRight
                                }
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
                                id: entryMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked:
                                menuEntry.activate()
                            }
                        }
                    }


                    // ============================================
                    // FOOTER
                    // ============================================

                    Rectangle {
                        Layout.fillWidth: true

                        Layout.topMargin: 10
                        Layout.bottomMargin: 12

                        height: 1

                        color: colors.border
                    }


                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "BE WARY, TARNISHED."

                            color: colors.muted

                            font.family: "serif"
                            font.pixelSize: 7
                            font.letterSpacing: 0.5
                        }


                        Item {
                            Layout.fillWidth: true
                        }


                        Text {
                            text: "TRY GRACE"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 8
                            font.bold: true
                            font.letterSpacing: 0.8
                        }
                    }
                }
            }
        }
    }
}
