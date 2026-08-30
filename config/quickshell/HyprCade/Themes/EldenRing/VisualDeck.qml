import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false

    property string selectionMode: "theme"

    property int selectedThemeIndex: 5
    property int selectedWallpaperIndex: 0

    Palette {
        id: colors
    }

    WallpaperRegistry {
        id: wallpaperRegistry
    }

    readonly property var themes: [
        {
            number: "I",
            id: "evangelion",
            name: "EVANGELION",
            available: true
        },
        {
            number: "II",
            id: "fullmetal-alchemist",
            name: "FULLMETAL ALCHEMIST",
            available: false
        },
        {
            number: "III",
            id: "cowboy-bebop",
            name: "COWBOY BEBOP",
            available: true
        },
        {
            number: "IV",
            id: "undertale",
            name: "UNDERTALE",
            available: false
        },
        {
            number: "V",
            id: "deltarune",
            name: "DELTARUNE",
            available: false
        },
        {
            number: "VI",
            id: "elden-ring",
            name: "ELDEN RING",
            available: true
        },
        {
            number: "VII",
            id: "ultrakill",
            name: "ULTRAKILL",
            available: false
        }
    ]

    readonly property var wallpapers:
        wallpaperRegistry.variants

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

    readonly property var selectedWallpaper:
        wallpapers.length > 0
        ? wallpapers[Math.min(
            selectedWallpaperIndex,
            wallpapers.length - 1
        )]
        : null

    readonly property bool selectedWallpaperActive:
        selectedWallpaper
        ? selectedWallpaper.id
            === wallpaperRegistry.activeId
        : false

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

        root.selectedThemeIndex = 5
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
        ) {
            return
        }

        Quickshell.execDetached([
            "/home/emo/Programs/HyprCade/scripts/set-wallpaper.sh",
            colors.themeId,
            root.selectedWallpaper.id
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

            implicitHeight: 430

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeDeck()
            }

            Rectangle {
                id: deck

                anchors.horizontalCenter:
                    parent.horizontalCenter

                width:
                    Math.min(
                        parent.width - 48,
                        1360
                    )

                height: 398

                y:
                    root.opened
                    ? 14
                    : parent.height + 16

                color: colors.background

                border.width: 1
                border.color: colors.border

                Behavior on y {
                    NumberAnimation {
                        duration: 260
                        easing.type:
                            Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6

                    color: "transparent"

                    border.width: 1
                    border.color: colors.panelAlt
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    width: 160
                    height: 1

                    color: colors.yellow
                    opacity: 0.7
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 20
                        bottomMargin: 15
                        leftMargin: 22
                        rightMargin: 22
                    }

                    spacing: 0

                    // ====================================================
                    // HEADER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1

                            Text {
                                text:
                                    "SITES OF GRACE"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 15
                                font.bold: true
                                font.letterSpacing: 1.5
                            }

                            Text {
                                text:
                                    "HYPRCADE  //  REALMS & VISIONS"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.8
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: 1

                            Text {
                                anchors.right:
                                    parent.right

                                text:
                                    colors.themeName
                                        .toUpperCase()

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                anchors.right:
                                    parent.right

                                text:
                                    "CURRENT REALM  //  "
                                    + colors.systemName
                                        .toUpperCase()

                                color: colors.blue

                                font.family: "serif"
                                font.pixelSize: 7
                                font.letterSpacing: 0.6
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

                    // ====================================================
                    // REALMS / THEMES
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "REALMS"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                                root.selectedTheme
                                ? "CHOSEN  //  "
                                    + root.selectedTheme.name
                                : "NO REALM"

                            color:
                                root.selectedThemeAvailable
                                ? colors.text
                                : colors.muted

                            font.family: "serif"
                            font.pixelSize: 8
                            font.italic: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        spacing: 7

                        Repeater {
                            model: root.themes

                            Rectangle {
                                id: realmCard

                                required property int index
                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredWidth: 1

                                height: 78

                                readonly property bool selected:
                                    root.selectedThemeIndex
                                    === index

                                readonly property bool active:
                                    modelData.id
                                    === colors.themeId

                                color:
                                    selected
                                    ? colors.panelAlt
                                    : colors.panel

                                border.width: 1

                                border.color:
                                    active
                                    ? colors.yellow
                                    : selected
                                        ? colors.blue
                                        : colors.border

                                Rectangle {
                                    visible:
                                        active || selected

                                    anchors {
                                        top: parent.top
                                        horizontalCenter:
                                            parent.horizontalCenter
                                    }

                                    width:
                                        active ? 42 : 26

                                    height: 1

                                    color:
                                        active
                                        ? colors.yellow
                                        : colors.blue
                                }

                                Text {
                                    anchors {
                                        top: parent.top
                                        topMargin: 7

                                        horizontalCenter:
                                            parent.horizontalCenter
                                    }

                                    text: modelData.number

                                    color:
                                        active
                                        ? colors.yellow
                                        : colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 8
                                    font.bold: true
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right

                                        leftMargin: 8
                                        rightMargin: 8

                                        verticalCenter:
                                            parent.verticalCenter
                                    }

                                    text: modelData.name

                                    horizontalAlignment:
                                        Text.AlignHCenter

                                    color:
                                        modelData.available
                                        ? (
                                            selected
                                            ? colors.text
                                            : colors.muted
                                        )
                                        : colors.muted

                                    opacity:
                                        modelData.available
                                        ? 1.0
                                        : 0.45

                                    font.family: "serif"
                                    font.pixelSize: 9
                                    font.bold: selected

                                    elide: Text.ElideRight
                                }

                                Text {
                                    anchors {
                                        bottom: parent.bottom
                                        bottomMargin: 7

                                        horizontalCenter:
                                            parent.horizontalCenter
                                    }

                                    text:
                                        active
                                        ? "CURRENT"
                                        : modelData.available
                                            ? "REVEALED"
                                            : "VEILED"

                                    color:
                                        active
                                        ? colors.yellow
                                        : modelData.available
                                            ? colors.blue
                                            : colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 7
                                    font.italic: true
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true
                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedThemeIndex =
                                        realmCard.index

                                        root.selectionMode = "theme"

                                        keyHandler
                                        .forceActiveFocus()
                                    }

                                    onDoubleClicked: {
                                        root.selectedThemeIndex =
                                        realmCard.index

                                        root.selectionMode = "theme"

                                        if (modelData.available)
                                            root.applySelectedTheme()

                                            keyHandler
                                            .forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 11
                        Layout.bottomMargin: 10

                        height: 1
                        color: colors.border
                    }

                    // ====================================================
                    // VISIONS / WALLPAPER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "VISIONS"

                            color: colors.blue

                            font.family: "serif"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                                root.selectedWallpaper
                                ? "CHOSEN  //  "
                                    + root.selectedWallpaper.name
                                : "NO VISION RECORDED"

                            color:
                                root.selectedWallpaper
                                ? colors.text
                                : colors.muted

                            font.family: "serif"
                            font.pixelSize: 8
                            font.italic: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 7

                        spacing: 14

                        ListView {
                            id: wallpaperList

                            Layout.fillWidth: true
                            Layout.preferredHeight: 112

                            orientation:
                                ListView.Horizontal

                            spacing: 9
                            clip: true

                            model: root.wallpapers

                            currentIndex:
                                root.selectedWallpaperIndex

                            delegate: Rectangle {
                                id: visionCard

                                required property int index
                                required property var modelData

                                width: 220
                                height: 104

                                readonly property bool selected:
                                    root.selectedWallpaperIndex
                                    === index

                                readonly property bool active:
                                    modelData.id
                                    === wallpaperRegistry.activeId

                                color: colors.panel

                                border.width: 1

                                border.color:
                                    active
                                    ? colors.yellow
                                    : selected
                                        ? colors.blue
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

                                    height: 25

                                    color: Qt.rgba(
                                        colors.background.r,
                                        colors.background.g,
                                        colors.background.b,
                                        0.91
                                    )

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: 8

                                            verticalCenter:
                                                parent.verticalCenter
                                        }

                                        text:
                                            "VISION "
                                            + (visionCard.index + 1)
                                            + "  //  "
                                            + modelData.name

                                        color: colors.text

                                        font.family: "serif"
                                        font.pixelSize: 8
                                    }

                                    Text {
                                        anchors {
                                            right: parent.right
                                            rightMargin: 8

                                            verticalCenter:
                                                parent.verticalCenter
                                        }

                                        text:
                                            active
                                            ? "BOUND"
                                            : selected
                                                ? "CHOSEN"
                                                : ""

                                        color:
                                            active
                                            ? colors.yellow
                                            : colors.blue

                                        font.family: "serif"
                                        font.pixelSize: 7
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedWallpaperIndex =
                                        visionCard.index

                                        root.selectionMode = "wallpaper"

                                        wallpaperList
                                        .positionViewAtIndex(
                                            visionCard.index,
                                            ListView.Contain
                                        )

                                        keyHandler
                                        .forceActiveFocus()
                                    }

                                    onDoubleClicked: {
                                        root.selectedWallpaperIndex =
                                        visionCard.index

                                        root.selectionMode = "wallpaper"

                                        root.applySelectedWallpaper()

                                        keyHandler
                                        .forceActiveFocus()
                                    }
                                }
                            }
                        }



                        Rectangle {
                            Layout.preferredWidth: 270
                            Layout.preferredHeight: 104

                            color: colors.panel

                            border.width: 1

                            border.color:
                                root.selectedThemeActive
                                ? colors.yellow
                                : root.selectedThemeAvailable
                                    ? colors.blue
                                    : colors.border

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 11

                                spacing: 2

                                Text {
                                    text:
                                        root.selectedTheme
                                        ? root.selectedTheme.name
                                        : "NONE"

                                    color:
                                        root.selectedThemeAvailable
                                        ? colors.text
                                        : colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Text {
                                    text:
                                        root.selectedThemeActive
                                        ? "REALM  //  CURRENT"
                                        : root.selectedThemeAvailable
                                            ? "REALM  //  REVEALED"
                                            : "REALM  //  VEILED"

                                    color:
                                        root.selectedThemeActive
                                        ? colors.yellow
                                        : root.selectedThemeAvailable
                                            ? colors.blue
                                            : colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 7
                                    font.italic: true
                                }

                                Item {
                                    Layout.fillHeight: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 30

                                    color:
                                        realmApplyMouse.containsMouse
                                        && root.selectedThemeAvailable
                                        ? colors.panelAlt
                                        : "transparent"

                                    border.width: 1

                                    border.color:
                                        root.selectedThemeAvailable
                                        ? colors.yellow
                                        : colors.border

                                    Text {
                                        anchors.centerIn: parent

                                        text:
                                            root.selectedThemeActive
                                            ? "RESTORE REALM"
                                            : root.selectedThemeAvailable
                                                ? "ENTER REALM"
                                                : "LOST TO THE FOG"

                                        color:
                                            root.selectedThemeAvailable
                                            ? colors.yellow
                                            : colors.muted

                                        font.family: "serif"
                                        font.pixelSize: 8
                                        font.bold: true
                                        font.letterSpacing: 0.5
                                    }

                                    MouseArea {
                                        id: realmApplyMouse

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
                        }
                    }

                    Item {
                            Layout.preferredHeight: 12
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 9

                        height: 1
                        color: colors.border
                    }


                }
            }

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
                        root.moveThemeSelection(-1)
                        root.selectionMode = "theme"
                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                        === Qt.Key_Right
                    ) {
                        root.moveThemeSelection(1)
                        root.selectionMode = "theme"
                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                        === Qt.Key_Up
                    ) {
                        root.moveWallpaperSelection(-1)
                        root.selectionMode = "wallpaper"
                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                        === Qt.Key_Down
                    ) {
                        root.moveWallpaperSelection(1)
                        root.selectionMode = "wallpaper"
                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                            === Qt.Key_Return
                        || event.key
                            === Qt.Key_Enter
                    ) {
                        root.applySelectedTheme()

                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                            === Qt.Key_Space
                    ) {
                        root.applySelectedWallpaper()

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

                    if (
                        event.key
                        === Qt.Key_Escape
                    ) {
                        root.closeDeck()

                        event.accepted = true
                    }
                }
            }

            Component.onCompleted:
                keyHandler.forceActiveFocus()

            onVisibleChanged: {
                if (visible)
                    keyHandler.forceActiveFocus()
            }
        }
    }
}
