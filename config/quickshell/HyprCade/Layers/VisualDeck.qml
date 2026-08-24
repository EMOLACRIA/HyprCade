import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false

    property int selectedThemeIndex: 2
    property int selectedWallpaperIndex: 0

    Palette {
        id: colors
    }

    WallpaperRegistry {
        id: wallpaperRegistry
    }


    // ========================================================
    // REGISTRY
    // ========================================================

    readonly property var themes: [
        {
            number: "01",
            id: "evangelion",
            name: "EVANGELION",
            available: false
        },
        {
            number: "02",
            id: "fullmetal-alchemist",
            name: "FULLMETAL ALCHEMIST",
            available: false
        },
        {
            number: "03",
            id: "cowboy-bebop",
            name: "COWBOY BEBOP",
            available: true
        },
        {
            number: "04",
            id: "undertale",
            name: "UNDERTALE",
            available: false
        },
        {
            number: "05",
            id: "deltarune",
            name: "DELTARUNE",
            available: false
        },
        {
            number: "06",
            id: "elden-ring",
            name: "ELDEN RING",
            available: false
        },
        {
            number: "07",
            id: "ultrakill",
            name: "ULTRAKILL",
            available: false
        }
    ]


    readonly property var wallpapers:
    wallpaperRegistry.variants

    readonly property var selectedWallpaper:
    wallpapers.length > 0
    ? wallpapers[Math.min(
        selectedWallpaperIndex,
        wallpapers.length - 1
    )]
    : null

    readonly property bool selectedWallpaperActive:
    selectedWallpaper
    ? selectedWallpaper.id === wallpaperRegistry.activeId
    : false


    readonly property var selectedTheme:
    themes[selectedThemeIndex]

    readonly property bool selectedThemeAvailable:
    selectedTheme
    ? selectedTheme.available
    : false

    readonly property bool selectedThemeActive:
    selectedTheme
    ? selectedTheme.id === colors.themeId
    : false


    // ========================================================
    // STATE
    // ========================================================

    function syncSelection(): void {
        for (let i = 0; i < root.themes.length; ++i) {
            if (root.themes[i].id === colors.themeId) {
                root.selectedThemeIndex = i
                return
            }
        }

        root.selectedThemeIndex = 2
    }


    function openDeck(): void {
        hideTimer.stop()

        root.syncSelection()
        root.syncWallpaperSelection()

        root.windowVisible = true
        root.opened = true
    }


    function closeDeck(): void {
        root.opened = false
        hideTimer.restart()
    }


    function toggleDeck(): void {
        if (root.opened)
            root.closeDeck()
            else
                root.openDeck()
    }


    function moveThemeSelection(delta): void {
        let next = root.selectedThemeIndex + delta

        if (next < 0)
            next = root.themes.length - 1

            if (next >= root.themes.length)
                next = 0

                root.selectedThemeIndex = next
    }

    function syncWallpaperSelection(): void {
        for (let i = 0; i < root.wallpapers.length; ++i) {
            if (
                root.wallpapers[i].id
                === wallpaperRegistry.activeId
            ) {
                root.selectedWallpaperIndex = i
                return
            }
        }

        root.selectedWallpaperIndex = 0
    }


    function moveWallpaperSelection(delta): void {
        if (root.wallpapers.length === 0)
            return

            let next =
            root.selectedWallpaperIndex + delta

            if (next < 0)
                next = root.wallpapers.length - 1

                if (next >= root.wallpapers.length)
                    next = 0

                    root.selectedWallpaperIndex = next
    }


    function applySelectedWallpaper(): void {
        if (!root.selectedWallpaper)
            return

            if (colors.themeId !== wallpaperRegistry.themeId)
                return

                Quickshell.execDetached([
                    "/home/emo/Programs/HyprCade/scripts/set-wallpaper.sh",
                    colors.themeId,
                    root.selectedWallpaper.id
                ])
    }


    function applySelectedTheme(): void {
        if (!root.selectedThemeAvailable)
            return

            Quickshell.execDetached([
                "/home/emo/Programs/HyprCade/scripts/apply-theme.sh",
                root.selectedTheme.id
            ])
    }


    Timer {
        id: hideTimer

        interval: 240

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }


    // ========================================================
    // IPC
    // ========================================================

    IpcHandler {
        target: "visualdeck"

        function toggle(): void {
            root.toggleDeck()
        }

        function open(): void {
            root.openDeck()
        }

        function close(): void {
            root.closeDeck()
        }
    }


    // ========================================================
    // WINDOW
    // ========================================================

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData

            screen: modelData
            visible: root.windowVisible

            anchors {
                left: true
                right: true
                bottom: true
            }

            implicitHeight: 382

            exclusiveZone: 0
            color: "transparent"

            focusable: true


            // Click the empty strip around the deck to close.
            MouseArea {
                anchors.fill: parent

                onClicked: root.closeDeck()
            }


            // =================================================
            // DECK BODY
            // =================================================

            Rectangle {
                id: deck

                anchors.horizontalCenter: parent.horizontalCenter

                width: Math.min(parent.width - 40, 1320)
                height: 350

                y: root.opened
                ? 14
                : parent.height + 12

                color: colors.background

                border.width: 1
                border.color: colors.border


                Behavior on y {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutCubic
                    }
                }


                // Top identification stripe.
                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                    }

                    width: 210
                    height: 4

                    color: colors.red
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 216
                    }

                    width: 72
                    height: 4

                    color: colors.yellow
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 294
                    }

                    width: 36
                    height: 4

                    color: colors.blue
                }


                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 19
                        bottomMargin: 14
                        leftMargin: 20
                        rightMargin: 20
                    }

                    spacing: 0


                    // =========================================
                    // HEADER
                    // =========================================

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1

                            Text {
                                text: "HYPRCADE"

                                color: colors.red

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true
                                font.letterSpacing: 1.5
                            }

                            Text {
                                text: "VISUAL DECK"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 2
                            }

                            Text {
                                text:
                                "THEME // WALLPAPER CONTROL"

                                color: colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }
                        }


                        Item {
                            Layout.fillWidth: true
                        }


                        Column {
                            spacing: 2

                            Text {
                                anchors.right: parent.right

                                text:
                                colors.systemName.toUpperCase()

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                anchors.right: parent.right

                                text:
                                "ACTIVE // "
                                + colors.themeName.toUpperCase()

                                color: colors.teal

                                font.family: "monospace"
                                font.pixelSize: 8
                            }
                        }
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.bottomMargin: 10

                        height: 1
                        color: colors.border
                    }


                    // =========================================
                    // THEMES
                    // =========================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "THEMES"

                            color: colors.yellow

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            "SELECTED // "
                            + root.selectedTheme.name

                            color:
                            root.selectedThemeAvailable
                            ? colors.text
                            : colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }
                    }


                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        spacing: 7

                        Repeater {
                            model: root.themes

                            Rectangle {
                                required property int index
                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredWidth: 1

                                height: 72

                                readonly property bool selected:
                                root.selectedThemeIndex === index

                                readonly property bool active:
                                modelData.id === colors.themeId

                                color:
                                selected
                                ? colors.panelAlt
                                : colors.panel

                                border.width: 1

                                border.color:
                                active
                                ? colors.red
                                : selected
                                ? colors.yellow
                                : colors.border


                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }

                                    width:
                                    active
                                    ? 4
                                    : selected
                                    ? 3
                                    : 0

                                    color:
                                    active
                                    ? colors.red
                                    : colors.yellow
                                }


                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        top: parent.top
                                        topMargin: 8
                                    }

                                    text: modelData.number

                                    color:
                                    active
                                    ? colors.red
                                    : colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 8
                                    font.bold: true
                                }


                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        leftMargin: 10
                                        rightMargin: 7

                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    text: modelData.name

                                    color:
                                    modelData.available
                                    ? colors.text
                                    : colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                    font.bold: true

                                    elide: Text.ElideRight
                                }


                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        bottom: parent.bottom
                                        bottomMargin: 7
                                    }

                                    text:
                                    active
                                    ? "ACTIVE"
                                    : modelData.available
                                    ? "READY"
                                    : "OFFLINE"

                                    color:
                                    active
                                    ? colors.teal
                                    : modelData.available
                                    ? colors.blue
                                    : colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 7
                                    font.bold: true
                                }


                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true
                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedThemeIndex =
                                        index

                                        keyHandler.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 11
                        Layout.bottomMargin: 9

                        height: 1
                        color: colors.border
                    }


                    // =========================================
                    // WALLPAPER
                    // =========================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "WALLPAPER"

                            color: colors.blue

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.1
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.selectedWallpaper
                            ? "SELECTED // "
                            + root.selectedWallpaper.name
                            : "NO WALLPAPER DATA"

                            color:
                            root.selectedWallpaper
                            ? colors.text
                            : colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }
                    }


                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 7

                        spacing: 14


                        // ─────────────────────────────────
                        // THUMBNAILS
                        // ─────────────────────────────────

                        ListView {
                            id: wallpaperList

                            Layout.fillWidth: true
                            Layout.preferredHeight: 102

                            orientation: ListView.Horizontal

                            spacing: 8
                            clip: true

                            model: root.wallpapers

                            currentIndex:
                            root.selectedWallpaperIndex

                            delegate: Rectangle {
                                required property int index
                                required property var modelData

                                width: 210
                                height: 96

                                readonly property bool selected:
                                root.selectedWallpaperIndex === index

                                readonly property bool active:
                                modelData.id
                                === wallpaperRegistry.activeId

                                color: colors.panel

                                border.width: 1

                                border.color:
                                active
                                ? colors.red
                                : selected
                                ? colors.yellow
                                : colors.border

                                clip: true


                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    source:
                                    wallpaperRegistry.imageSource(
                                        modelData.path
                                    )

                                    fillMode:
                                    Image.PreserveAspectCrop

                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                }


                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                    }

                                    height: 24

                                    color:
                                    Qt.rgba(
                                        colors.background.r,
                                        colors.background.g,
                                        colors.background.b,
                                        0.90
                                    )


                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.verticalCenter:
                                        parent.verticalCenter

                                        text:
                                        String(index + 1)
                                        .padStart(2, "0")
                                        + " // "
                                        + modelData.name

                                        color: colors.text

                                        font.family: "monospace"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }


                                    Text {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter:
                                        parent.verticalCenter

                                        text:
                                        active
                                        ? "ACTIVE"
                                        : selected
                                        ? "SELECTED"
                                        : ""

                                        color:
                                        active
                                        ? colors.teal
                                        : colors.yellow

                                        font.family: "monospace"
                                        font.pixelSize: 7
                                        font.bold: true
                                    }
                                }


                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedWallpaperIndex =
                                        index

                                        wallpaperList.positionViewAtIndex(
                                            index,
                                            ListView.Contain
                                        )

                                        keyHandler.forceActiveFocus()
                                    }

                                    onDoubleClicked: {
                                        root.selectedWallpaperIndex =
                                        index

                                        root.applySelectedWallpaper()
                                    }
                                }
                            }
                        }


                        // ─────────────────────────────────
                        // WALLPAPER COMMAND
                        // ─────────────────────────────────

                        Rectangle {
                            Layout.preferredWidth: 250
                            Layout.preferredHeight: 96

                            color: colors.panel

                            border.width: 1
                            border.color:
                            root.selectedWallpaperActive
                            ? colors.teal
                            : colors.border


                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                spacing: 2


                                Text {
                                    text:
                                    root.selectedWallpaper
                                    ? "> "
                                    + root.selectedWallpaper.name
                                    : "> NONE"

                                    color: colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    font.bold: true
                                }


                                Text {
                                    text:
                                    root.selectedWallpaperActive
                                    ? "STATUS // ACTIVE"
                                    : "STATUS // READY"

                                    color:
                                    root.selectedWallpaperActive
                                    ? colors.teal
                                    : colors.yellow

                                    font.family: "monospace"
                                    font.pixelSize: 7
                                }


                                Item {
                                    Layout.fillHeight: true
                                }


                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 30

                                    color:
                                    wallpaperApplyMouse.containsMouse
                                    ? colors.panelAlt
                                    : "transparent"

                                    border.width: 1
                                    border.color: colors.blue


                                    Text {
                                        anchors.centerIn: parent

                                        text:
                                        root.selectedWallpaperActive
                                        ? "[ REAPPLY WALLPAPER ]"
                                        : "[ APPLY WALLPAPER ]"

                                        color: colors.blue

                                        font.family: "monospace"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }


                                    MouseArea {
                                        id: wallpaperApplyMouse

                                        anchors.fill: parent

                                        hoverEnabled: true
                                        cursorShape:
                                        Qt.PointingHandCursor

                                        onClicked: {
                                            root.applySelectedWallpaper()
                                            keyHandler.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }


                        // =====================================
                        // SELECTED THEME STATUS
                        // =====================================

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            spacing: 0


                            Text {
                                text: "SELECTION"

                                color: colors.red

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1.1
                            }


                            Text {
                                Layout.topMargin: 5

                                text:
                                "> "
                                + root.selectedTheme.name

                                color:
                                root.selectedThemeAvailable
                                ? colors.text
                                : colors.muted

                                font.family: "monospace"
                                font.pixelSize: 13
                                font.bold: true
                            }


                            Text {
                                Layout.topMargin: 3

                                text:
                                root.selectedThemeActive
                                ? "STATUS // ACTIVE"
                                : root.selectedThemeAvailable
                                ? "STATUS // READY TO APPLY"
                                : "STATUS // THEME OFFLINE"

                                color:
                                root.selectedThemeActive
                                ? colors.teal
                                : root.selectedThemeAvailable
                                ? colors.yellow
                                : colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }


                            Item {
                                Layout.fillHeight: true
                            }


                            Rectangle {
                                Layout.fillWidth: true

                                height: 34

                                color:
                                applyMouse.containsMouse
                                && root.selectedThemeAvailable
                                ? colors.panelAlt
                                : "transparent"

                                border.width: 1

                                border.color:
                                root.selectedThemeAvailable
                                ? colors.red
                                : colors.border


                                Text {
                                    anchors.centerIn: parent

                                    text:
                                    root.selectedThemeActive
                                    ? "[ REAPPLY ACTIVE THEME ]"
                                    : root.selectedThemeAvailable
                                    ? "[ ENTER // APPLY THEME ]"
                                    : "[ THEME DATA NOT INSTALLED ]"

                                    color:
                                    root.selectedThemeAvailable
                                    ? colors.red
                                    : colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                    font.bold: true
                                }


                                MouseArea {
                                    id: applyMouse

                                    anchors.fill: parent

                                    enabled:
                                    root.selectedThemeAvailable

                                    hoverEnabled: true

                                    cursorShape:
                                    enabled
                                    ? Qt.PointingHandCursor
                                    : Qt.ArrowCursor

                                    onClicked: {
                                        root.applySelectedTheme()
                                        keyHandler.forceActiveFocus()
                                    }
                                }
                            }
                        }



                    Item {
                        Layout.fillHeight: true
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 9

                        height: 1
                        color: colors.border
                    }


                    // =========================================
                    // FOOTER
                    // =========================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "← → SELECT THEME"
                            + "   //   "
                            + "ENTER APPLY"

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            "WALLPAPER // 01 VARIANT"
                            + "   //   "
                            + "ESC CLOSE"

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }
                    }
                }
            }


            // =================================================
            // KEYBOARD CONTROL
            // =================================================

            FocusScope {
                id: keyHandler

                anchors.fill: parent
                focus: true

                Keys.onPressed: function(event) {
                    if (!root.opened)
                        return

                        if (event.key === Qt.Key_Left) {
                            root.moveThemeSelection(-1)
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Right) {
                            root.moveThemeSelection(1)
                            event.accepted = true
                            return
                        }

                        if (
                            event.key === Qt.Key_Return
                            || event.key === Qt.Key_Enter
                        ) {
                            root.applySelectedTheme()

                            event.accepted = true
                            return
                        }

                        if (
                            event.key >= Qt.Key_1
                            && event.key <= Qt.Key_7
                        ) {
                            root.selectedThemeIndex =
                            event.key - Qt.Key_1

                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Escape) {
                            root.closeDeck()

                            event.accepted = true
                        }
                }
            }


            Component.onCompleted: {
                keyHandler.forceActiveFocus()
            }

            onVisibleChanged: {
                if (visible)
                    keyHandler.forceActiveFocus()
            }
        }
    }
}
