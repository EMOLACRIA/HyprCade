import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../../Data"

Scope {
    id: root

    property string selectionMode: "theme"

    property bool opened: false
    property bool windowVisible: false

    property int selectedThemeIndex: 0
    property int selectedWallpaperIndex: 0

    Palette {
        id: colors
    }

    WallpaperRegistry {
        id: wallpaperRegistry
    }

    // ============================================================
    // REGISTRY
    // ============================================================

    readonly property var themes: [
        {
            number: "01",
            id: "evangelion",
            name: "EVANGELION",
            available: true
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
            available: true
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
    ? wallpapers[
        Math.min(
            selectedWallpaperIndex,
            wallpapers.length - 1
        )
    ]
    : null

    readonly property bool selectedWallpaperActive:
    selectedWallpaper
    ? selectedWallpaper.id
    === wallpaperRegistry.activeId
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

    // ============================================================
    // STATE
    // ============================================================

    function syncSelection(): void {
        for (
            let i = 0;
        i < root.themes.length;
        ++i
        ) {
            if (
                root.themes[i].id
                === colors.themeId
            ) {
                root.selectedThemeIndex = i
                return
            }
        }

        root.selectedThemeIndex = 0
    }

    function syncWallpaperSelection(): void {
        for (
            let i = 0;
        i < root.wallpapers.length;
        ++i
        ) {
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

    function openDeck(): void {
        hideTimer.stop()

        root.syncSelection()
        root.syncWallpaperSelection()

        root.selectionMode = "theme"

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
        let next =
        root.selectedThemeIndex + delta

        if (next < 0)
            next = root.themes.length - 1

            if (next >= root.themes.length)
                next = 0

                root.selectedThemeIndex = next
                root.selectionMode = "theme"
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
                    root.selectionMode = "wallpaper"

                    wallpaperList.positionViewAtIndex(
                        next,
                        ListView.Contain
                    )
    }

    function applySelectedTheme(): void {
        if (!root.selectedThemeAvailable)
            return

            Quickshell.execDetached([
                "/home/emo/Programs/HyprCade/scripts/apply-theme.sh",
                root.selectedTheme.id
            ])
    }

    function applySelectedWallpaper(): void {
        if (!root.selectedWallpaper)
            return

            if (
                colors.themeId
                !== wallpaperRegistry.themeId
            )
                return

                Quickshell.execDetached([
                    "/home/emo/Programs/HyprCade/scripts/set-wallpaper.sh",
                    colors.themeId,
                    root.selectedWallpaper.id
                ])
    }

    function applySelection(): void {
        if (
            root.selectionMode
            === "wallpaper"
        ) {
            root.applySelectedWallpaper()
            return
        }

        root.applySelectedTheme()
    }

    Timer {
        id: hideTimer

        interval: 220

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }

    // ============================================================
    // IPC
    // ============================================================

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
                left: true
                right: true
                bottom: true
            }

            implicitHeight: 382

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.closeDeck()
                }
            }

            Rectangle {
                id: deckSurface

                anchors.horizontalCenter:
                parent.horizontalCenter

                width:
                Math.min(
                    parent.width - 40,
                    1320
                )

                height: 350

                y:
                root.opened
                ? 14
                : parent.height + 12

                color: "#090909"

                border.width: 1
                border.color: "#292929"

                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing.type:
                        Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                    function(mouse) {
                        mouse.accepted = true
                    }
                }

                // NERV identification marker
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 3
                    color: colors.red
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 18
                        bottomMargin: 14
                        leftMargin: 21
                        rightMargin: 20
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
                                text:
                                "MAGI CONFIGURATION"

                                color: "#D8D8D8"

                                font.family:
                                "monospace"

                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.3
                            }

                            Text {
                                text:
                                "VISUAL SYSTEM CONTROL"

                                color: "#5B5B5B"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                                font.letterSpacing: 0.7
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: -2

                            Text {
                                anchors.right:
                                parent.right

                                text:
                                "NERV // MAGI"

                                color: "#666666"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                                font.bold: true
                            }

                            Text {
                                anchors.right:
                                parent.right

                                text:
                                colors.themeName
                                .toUpperCase()

                                color: "#999999"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                            }
                        }

                        Text {
                            text: "●"

                            color: colors.red
                            font.pixelSize: 6
                        }
                    }

                    Divider {
                        Layout.topMargin: 12
                        Layout.bottomMargin: 10
                    }

                    // ====================================================
                    // THEMES
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "CONFIGURATION"

                            color: "#626262"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.9
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
                            ? "#777777"
                            : "#444444"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        spacing: 6

                        Repeater {
                            model: root.themes

                            Rectangle {
                                id: themeEntry

                                required property int index
                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredWidth: 1

                                height: 71

                                readonly property bool selected:
                                root.selectedThemeIndex
                                === index

                                readonly property bool active:
                                modelData.id
                                === colors.themeId

                                color:
                                selected
                                ? "#111111"
                                : "#0C0C0C"

                                border.width: 1

                                border.color:
                                active
                                ? colors.red
                                : selected
                                ? "#3B3B3B"
                                : "#222222"

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }

                                    width:
                                    active
                                    ? 3
                                    : selected
                                    ? 2
                                    : 0

                                    color:
                                    active
                                    ? colors.red
                                    : "#4B4B4B"
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 9
                                        top: parent.top
                                        topMargin: 7
                                    }

                                    text:
                                    modelData.number

                                    color:
                                    active
                                    ? colors.red
                                    : "#444444"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 7
                                    font.bold: true
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right

                                        leftMargin: 9
                                        rightMargin: 7

                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    text:
                                    modelData.name

                                    color:
                                    modelData.available
                                    ? (
                                        selected
                                        ? "#D0D0D0"
                                        : "#8A8A8A"
                                    )
                                    : "#454545"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 8
                                    font.bold: true

                                    elide:
                                    Text.ElideRight
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 9
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
                                    ? colors.red
                                    : modelData.available
                                    ? "#696969"
                                    : "#383838"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 6
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedThemeIndex =
                                        themeEntry.index

                                        root.selectionMode =
                                        "theme"

                                        keyHandler
                                        .forceActiveFocus()
                                    }

                                    onDoubleClicked: {
                                        root.selectedThemeIndex =
                                        themeEntry.index

                                        root.selectionMode =
                                        "theme"

                                        if (
                                            themeEntry
                                            .modelData
                                            .available
                                        ) {
                                            root
                                            .applySelectedTheme()
                                        }

                                        keyHandler
                                        .forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 11
                        Layout.bottomMargin: 9
                    }

                    // ====================================================
                    // WALLPAPER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "WALLPAPER"

                            color: "#626262"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.9
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.selectedWallpaper
                            ? (
                                "SELECTED // "
                                + root
                                .selectedWallpaper
                                .name
                            )
                            : "NO WALLPAPER DATA"

                            color:
                            root.selectedWallpaper
                            ? "#777777"
                            : "#444444"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 7

                        spacing: 13

                        ListView {
                            id: wallpaperList

                            Layout.fillWidth: true
                            Layout.preferredHeight: 102

                            orientation:
                            ListView.Horizontal

                            spacing: 8
                            clip: true

                            model:
                            root.wallpapers

                            currentIndex:
                            root.selectedWallpaperIndex

                            delegate: Rectangle {
                                id: wallpaperEntry

                                required property int index
                                required property var modelData

                                width: 210
                                height: 96

                                readonly property bool selected:
                                root.selectedWallpaperIndex
                                === index

                                readonly property bool active:
                                modelData.id
                                === wallpaperRegistry
                                .activeId

                                color: "#0C0C0C"

                                border.width: 1

                                border.color:
                                active
                                ? colors.red
                                : selected
                                ? "#3B3B3B"
                                : "#222222"

                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    source:
                                    wallpaperRegistry
                                    .imageSource(
                                        wallpaperEntry
                                        .modelData
                                        .path
                                    )

                                    fillMode:
                                    Image
                                    .PreserveAspectCrop

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

                                    color: "#E6090909"

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: 8
                                            verticalCenter:
                                            parent.verticalCenter
                                        }

                                        text:
                                        String(
                                            wallpaperEntry
                                            .index + 1
                                        ).padStart(
                                            2,
                                            "0"
                                        )
                                        + " // "
                                        + wallpaperEntry
                                        .modelData
                                        .name

                                        color: "#B5B5B5"

                                        font.family:
                                        "monospace"

                                        font.pixelSize: 7
                                        font.bold: true
                                    }

                                    Text {
                                        anchors {
                                            right: parent.right
                                            rightMargin: 8
                                            verticalCenter:
                                            parent.verticalCenter
                                        }

                                        text:
                                        wallpaperEntry.active
                                        ? "ACTIVE"
                                        : wallpaperEntry.selected
                                        ? "SELECTED"
                                        : ""

                                        color:
                                        wallpaperEntry.active
                                        ? colors.red
                                        : "#666666"

                                        font.family:
                                        "monospace"

                                        font.pixelSize: 6
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedWallpaperIndex =
                                        wallpaperEntry.index

                                        root.selectionMode =
                                        "wallpaper"

                                        wallpaperList
                                        .positionViewAtIndex(
                                            wallpaperEntry.index,
                                            ListView.Contain
                                        )

                                        keyHandler
                                        .forceActiveFocus()
                                    }

                                    onDoubleClicked: {
                                        root.selectedWallpaperIndex =
                                        wallpaperEntry.index

                                        root.selectionMode =
                                        "wallpaper"

                                        root
                                        .applySelectedWallpaper()

                                        keyHandler
                                        .forceActiveFocus()
                                    }
                                }
                            }
                        }

                        // =================================================
                        // ACTION BLOCK
                        // =================================================

                        Rectangle {
                            id: actionBlock

                            Layout.preferredWidth: 248
                            Layout.preferredHeight: 96

                            readonly property bool themeMode:
                            root.selectionMode
                            === "theme"

                            readonly property bool actionEnabled:
                            themeMode
                            ? root.selectedThemeAvailable
                            : root.selectedWallpaper
                            !== null

                            color: "#0C0C0C"

                            border.width: 1

                            border.color: {
                                if (themeMode) {
                                    if (
                                        root.selectedThemeActive
                                    )
                                        return colors.red

                                        if (
                                            root
                                            .selectedThemeAvailable
                                        )
                                            return "#333333"

                                            return "#222222"
                                }

                                return (
                                    root
                                    .selectedWallpaperActive
                                    ? colors.red
                                    : "#333333"
                                )
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                spacing: 1

                                Text {
                                    text: {
                                        if (
                                            actionBlock
                                            .themeMode
                                        ) {
                                            return (
                                                root.selectedTheme
                                                ? "> "
                                                + root
                                                .selectedTheme
                                                .name
                                                : "> NONE"
                                            )
                                        }

                                        return (
                                            root
                                            .selectedWallpaper
                                            ? "> "
                                            + root
                                            .selectedWallpaper
                                            .name
                                            : "> NONE"
                                        )
                                    }

                                    color:
                                    actionBlock.themeMode
                                    && !root
                                    .selectedThemeAvailable
                                    ? "#444444"
                                    : "#AFAFAF"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                Text {
                                    text: {
                                        if (
                                            actionBlock
                                            .themeMode
                                        ) {
                                            if (
                                                root
                                                .selectedThemeActive
                                            )
                                                return "STATUS // ACTIVE"

                                                if (
                                                    root
                                                    .selectedThemeAvailable
                                                )
                                                    return "STATUS // READY"

                                                    return "STATUS // OFFLINE"
                                        }

                                        return (
                                            root
                                            .selectedWallpaperActive
                                            ? "STATUS // ACTIVE"
                                            : "STATUS // READY"
                                        )
                                    }

                                    color: {
                                        if (
                                            actionBlock
                                            .themeMode
                                        ) {
                                            if (
                                                root
                                                .selectedThemeActive
                                            )
                                                return colors.red

                                                return "#555555"
                                        }

                                        return (
                                            root
                                            .selectedWallpaperActive
                                            ? colors.red
                                            : "#555555"
                                        )
                                    }

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 6
                                    font.bold: true
                                }

                                Item {
                                    Layout.fillHeight: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true

                                    height: 30

                                    color:
                                    actionMouse
                                    .containsMouse
                                    && actionBlock
                                    .actionEnabled
                                    ? "#151515"
                                    : "transparent"

                                    border.width: 1

                                    border.color:
                                    actionBlock
                                    .actionEnabled
                                    ? "#343434"
                                    : "#222222"

                                    Text {
                                        anchors.centerIn:
                                        parent

                                        text: {
                                            if (
                                                actionBlock
                                                .themeMode
                                            ) {
                                                if (
                                                    !root
                                                    .selectedThemeAvailable
                                                )
                                                    return "[ OFFLINE ]"

                                                    return (
                                                        root
                                                        .selectedThemeActive
                                                        ? "[ REAPPLY THEME ]"
                                                        : "[ APPLY THEME ]"
                                                    )
                                            }

                                            return (
                                                root
                                                .selectedWallpaperActive
                                                ? "[ REAPPLY WALLPAPER ]"
                                                : "[ APPLY WALLPAPER ]"
                                            )
                                        }

                                        color:
                                        actionBlock
                                        .actionEnabled
                                        ? (
                                            actionMouse
                                            .containsMouse
                                            ? colors.red
                                            : "#777777"
                                        )
                                        : "#3A3A3A"

                                        font.family:
                                        "monospace"

                                        font.pixelSize: 7
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: actionMouse

                                        anchors.fill: parent

                                        enabled:
                                        actionBlock
                                        .actionEnabled

                                        hoverEnabled: true

                                        cursorShape:
                                        enabled
                                        ? Qt
                                        .PointingHandCursor
                                        : Qt.ArrowCursor

                                        onClicked: {
                                            root
                                            .applySelection()

                                            keyHandler
                                            .forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 12
                    }

                    Divider {
                        Layout.bottomMargin: 9
                    }

                    // ====================================================
                    // FOOTER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "← → SELECT"
                            + "   //   "
                            + "ENTER APPLY"

                            color: "#454545"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            "CLICK SELECT"
                            + "   //   "
                            + "DOUBLE CLICK APPLY"
                            + "   //   "
                            + "ESC CLOSE"

                            color: "#454545"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                        }
                    }
                }
            }

            // ============================================================
            // KEYBOARD
            // ============================================================

            FocusScope {
                id: keyHandler

                anchors.fill: parent
                focus: true

                Keys.onPressed:
                function(event) {
                    if (!root.opened)
                        return

                        if (
                            event.key
                            === Qt.Key_Left
                        ) {
                            if (
                                root.selectionMode
                                === "wallpaper"
                            )
                                root
                                .moveWallpaperSelection(-1)
                                else
                                    root
                                    .moveThemeSelection(-1)

                                    event.accepted = true
                                    return
                        }

                        if (
                            event.key
                            === Qt.Key_Right
                        ) {
                            if (
                                root.selectionMode
                                === "wallpaper"
                            )
                                root
                                .moveWallpaperSelection(1)
                                else
                                    root
                                    .moveThemeSelection(1)

                                    event.accepted = true
                                    return
                        }

                        if (
                            event.key
                            === Qt.Key_Up
                        ) {
                            root.selectionMode = "theme"

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Down
                        ) {
                            if (
                                root.wallpapers.length
                                > 0
                            )
                                root.selectionMode =
                                "wallpaper"

                                event.accepted = true
                                return
                        }

                        if (
                            event.key
                            === Qt.Key_Return
                            || event.key
                            === Qt.Key_Enter
                        ) {
                            root.applySelection()

                            event.accepted = true
                            return
                        }

                        if (
                            event.key >= Qt.Key_1
                            && event.key <= Qt.Key_7
                        ) {
                            root.selectedThemeIndex =
                            event.key
                            - Qt.Key_1

                            root.selectionMode =
                            "theme"

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Escape
                        ) {
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

    component Divider: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1
        color: "#242424"
    }
}
