import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false

    property int selectedIndex: 0

    property bool confirming: false
    property int confirmIndex: -1

    readonly property var actions: [
        {
            number: "01",
            title: "LOCK SESSION",
            sub: "SECURITY // HYPRLOCK",
            accent: "blue"
        },
        {
            number: "02",
            title: "LOGOUT",
            sub: "SESSION // TERMINATE",
            accent: "yellow"
        },
        {
            number: "03",
            title: "REBOOT SYSTEM",
            sub: "SYSTEM // RESTART",
            accent: "teal"
        },
        {
            number: "04",
            title: "POWER OFF",
            sub: "SYSTEM // SHUTDOWN",
            accent: "red"
        }
    ]

    Palette {
        id: colors
    }


    // ─────────────────────────────────────
    // STATE
    // ─────────────────────────────────────

    function openMenu(): void {
        hideTimer.stop()

        root.selectedIndex = 0
        root.confirming = false
        root.confirmIndex = -1

        root.windowVisible = true
        root.opened = true
    }

    function closeMenu(): void {
        root.opened = false
        root.confirming = false
        root.confirmIndex = -1

        hideTimer.restart()
    }

    function toggleMenu(): void {
        if (root.opened)
            root.closeMenu()
            else
                root.openMenu()
    }


    // ─────────────────────────────────────
    // COLORS
    // ─────────────────────────────────────

    function accentFor(index): color {
        switch (index) {
            case 0:
                return colors.blue

            case 1:
                return colors.yellow

            case 2:
                return colors.teal

            case 3:
                return colors.red

            default:
                return colors.text
        }
    }


    // ─────────────────────────────────────
    // COMMANDS
    // ─────────────────────────────────────

    function requestAction(index): void {
        root.selectedIndex = index

        // Lock.
        if (index === 0) {
            root.closeMenu()

            Quickshell.execDetached([
                "sh",
                "-lc",
                "sleep 0.45; exec hyprlock"
            ])

            return
        }

        // Logout.
        if (index === 1) {
            root.closeMenu()

            Quickshell.execDetached([
                "uwsm",
                "stop"
            ])

            return
        }

        // Reboot / poweroff require confirmation.
        root.confirmIndex = index
        root.confirming = true
    }


    function executeConfirmed(): void {
        if (!root.confirming)
            return

            const index = root.confirmIndex

            root.confirming = false

            if (index === 2) {
                Quickshell.execDetached([
                    "systemctl",
                    "reboot"
                ])

                return
            }

            if (index === 3) {
                Quickshell.execDetached([
                    "systemctl",
                    "poweroff"
                ])
            }
    }


    function cancelConfirmation(): void {
        root.confirming = false
        root.confirmIndex = -1
    }


    function moveSelection(delta): void {
        if (root.confirming)
            return

            let next =
            root.selectedIndex + delta

            if (next < 0)
                next = root.actions.length - 1

                if (next >= root.actions.length)
                    next = 0

                    root.selectedIndex = next
    }


    Timer {
        id: hideTimer

        interval: 160

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }


    // ─────────────────────────────────────
    // IPC
    // ─────────────────────────────────────

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.toggleMenu()
        }

        function open(): void {
            root.openMenu()
        }

        function close(): void {
            root.closeMenu()
        }
    }


    // ─────────────────────────────────────
    // WINDOW
    // ─────────────────────────────────────

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData

            screen: modelData
            visible: root.windowVisible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0

            color: "transparent"

            focusable: true


            // ─────────────────────────────
            // DARK SCREEN WASH
            // ─────────────────────────────

            Rectangle {
                anchors.fill: parent

                color: Qt.rgba(
                    colors.background.r,
                    colors.background.g,
                    colors.background.b,
                    root.opened ? 0.78 : 0.0
                )

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!root.confirming)
                            root.closeMenu()
                    }
                }
            }


            // ─────────────────────────────
            // TERMINAL
            // ─────────────────────────────

            Rectangle {
                id: terminal

                anchors.centerIn: parent

                width: 510
                height: root.confirming ? 470 : 430

                opacity: root.opened ? 1 : 0

                scale: root.opened ? 1 : 0.96

                color: colors.background

                border.width: 1
                border.color:
                root.confirming
                ? root.accentFor(root.confirmIndex)
                : colors.border


                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }


                // Left system stripe.
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 5

                    color:
                    root.confirming
                    ? root.accentFor(root.confirmIndex)
                    : colors.red
                }


                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        leftMargin: 27
                        rightMargin: 22
                        topMargin: 22
                        bottomMargin: 18
                    }

                    spacing: 0


                    // ─────────────────────
                    // HEADER
                    // ─────────────────────

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 2

                            Text {
                                text: "HYPRCADE"

                                color: colors.red

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true
                                font.letterSpacing: 1.4
                            }

                            Text {
                                text:
                                colors.systemName.toUpperCase()
                                + " // CONTROL"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text:
                                root.confirming
                                ? "COMMAND AUTHORIZATION // REQUIRED"
                                : "SYSTEM COMMAND INTERFACE // NODE 01"

                                color:
                                root.confirming
                                ? root.accentFor(root.confirmIndex)
                                : colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.confirming
                            ? "CONFIRM"
                            : "READY"

                            color:
                            root.confirming
                            ? root.accentFor(root.confirmIndex)
                            : colors.teal

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 15
                        Layout.bottomMargin: 14

                        height: 1

                        color: colors.border
                    }


                    // ─────────────────────
                    // COMMAND LABEL
                    // ─────────────────────

                    Text {
                        text:
                        root.confirming
                        ? "PENDING COMMAND"
                        : "AVAILABLE COMMANDS"

                        color:
                        root.confirming
                        ? root.accentFor(root.confirmIndex)
                        : colors.yellow

                        font.family: "monospace"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }


                    // ─────────────────────
                    // ACTIONS
                    // ─────────────────────

                    Column {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 7

                        Repeater {
                            model: root.actions

                            Rectangle {
                                required property int index
                                required property var modelData

                                width: parent.width
                                height: 54

                                visible:
                                !root.confirming
                                || index === root.confirmIndex

                                color:
                                root.selectedIndex === index
                                ? colors.panel
                                : "transparent"

                                border.width: 1

                                border.color:
                                root.selectedIndex === index
                                ? root.accentFor(index)
                                : colors.border


                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }

                                    width:
                                    root.selectedIndex === index
                                    ? 4
                                    : 0

                                    color:
                                    root.accentFor(index)
                                }


                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 14

                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    text:
                                    modelData.number
                                    + "  "
                                    + modelData.title

                                    color:
                                    root.selectedIndex === index
                                    ? root.accentFor(index)
                                    : colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 11
                                    font.bold: true
                                }


                                Text {
                                    anchors {
                                        right: parent.right
                                        rightMargin: 13

                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    text: modelData.sub

                                    color: colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 8
                                }


                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        if (!root.confirming)
                                            root.selectedIndex = index
                                    }

                                    onClicked: {
                                        if (!root.confirming) {
                                            root.requestAction(index)
                                            keyHandler.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }


                    // ─────────────────────
                    // CONFIRMATION
                    // ─────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 14

                        height: root.confirming ? 62 : 0

                        visible: root.confirming

                        color: colors.panelAlt

                        border.width: 1
                        border.color:
                        root.accentFor(root.confirmIndex)


                        Column {
                            anchors.centerIn: parent

                            spacing: 5

                            Text {
                                anchors.horizontalCenter:
                                parent.horizontalCenter

                                text:
                                root.confirmIndex === 2
                                ? "REBOOT SYSTEM?"
                                : "POWER OFF SYSTEM?"

                                color:
                                root.accentFor(root.confirmIndex)

                                font.family: "monospace"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Text {
                                anchors.horizontalCenter:
                                parent.horizontalCenter

                                text:
                                "[ Y / ENTER ] CONFIRM"
                                + "     "
                                + "[ N / ESC ] ABORT"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 8
                            }
                        }
                    }


                    Item {
                        Layout.fillHeight: true
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 12

                        height: 1

                        color: colors.border
                    }


                    // ─────────────────────
                    // FOOTER
                    // ─────────────────────

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            root.confirming
                            ? "AUTHORIZATION // PENDING"
                            : "↑↓ SELECT // ENTER EXECUTE"

                            color:
                            root.confirming
                            ? root.accentFor(root.confirmIndex)
                            : colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.confirming
                            ? "ESC // ABORT"
                            : "1-4 DIRECT // ESC ABORT"

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                        }
                    }
                }
            }


            // ─────────────────────────────
            // KEYBOARD
            // ─────────────────────────────

            // ─────────────────────────────
            // KEYBOARD FOCUS
            // ─────────────────────────────

            FocusScope {
                id: keyHandler

                anchors.fill: parent

                focus: true

                Keys.onPressed: function(event) {
                    if (!root.opened)
                        return


                        // ─────────────────────
                        // CONFIRMATION MODE
                        // ─────────────────────

                        if (root.confirming) {
                            if (
                                event.key === Qt.Key_Y
                                || event.key === Qt.Key_Return
                                || event.key === Qt.Key_Enter
                            ) {
                                root.executeConfirmed()
                                event.accepted = true
                                return
                            }

                            if (
                                event.key === Qt.Key_N
                                || event.key === Qt.Key_Escape
                            ) {
                                root.cancelConfirmation()

                                // Keep keyboard control after aborting.
                                keyHandler.forceActiveFocus()

                                event.accepted = true
                                return
                            }

                            event.accepted = true
                            return
                        }


                        // ─────────────────────
                        // NORMAL MODE
                        // ─────────────────────

                        if (event.key === Qt.Key_Up) {
                            root.moveSelection(-1)
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Down) {
                            root.moveSelection(1)
                            event.accepted = true
                            return
                        }

                        if (
                            event.key === Qt.Key_Return
                            || event.key === Qt.Key_Enter
                        ) {
                            root.requestAction(root.selectedIndex)

                            // requestAction may enter confirmation mode.
                            keyHandler.forceActiveFocus()

                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_1) {
                            root.requestAction(0)
                            keyHandler.forceActiveFocus()
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_2) {
                            root.requestAction(1)
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_3) {
                            root.requestAction(2)
                            keyHandler.forceActiveFocus()
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_4) {
                            root.requestAction(3)
                            keyHandler.forceActiveFocus()
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Escape) {
                            root.closeMenu()
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
