import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../../Data"

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
            title: "LOCK",
            subtitle: "SECURE ACTIVE SESSION"
        },
        {
            number: "02",
            title: "LOGOUT",
            subtitle: "TERMINATE USER SESSION"
        },
        {
            number: "03",
            title: "REBOOT",
            subtitle: "RESTART PRIMARY SYSTEM"
        },
        {
            number: "04",
            title: "POWER OFF",
            subtitle: "TERMINATE PRIMARY SYSTEM"
        }
    ]

    Palette {
        id: colors
    }

    // ============================================================
    // STATE
    // ============================================================

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

        interval: 140

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }

    // ============================================================
    // COMMANDS
    // ============================================================

    function requestAction(index): void {
        root.selectedIndex = index

        if (index === 0) {
            root.closeMenu()

            Quickshell.execDetached([
                "sh",
                "-lc",
                "sleep 0.45; exec hyprlock"
            ])

            return
        }

        if (index === 1) {
            root.closeMenu()

            Quickshell.execDetached([
                "uwsm",
                "stop"
            ])

            return
        }

        root.confirmIndex = index
        root.confirming = true
    }

    function executeConfirmed(): void {
        if (!root.confirming)
            return

            const index =
            root.confirmIndex

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

    // ============================================================
    // IPC
    // ============================================================

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
                right: true
            }

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            Rectangle {
                anchors.fill: parent

                color: "#000000"

                opacity:
                root.opened
                ? 0.72
                : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 130
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

            // ====================================================
            // NORMAL MODE
            // ====================================================

            Rectangle {
                id: powerConsole

                anchors.centerIn: parent

                width:
                root.confirming
                ? 600
                : 520

                height:
                root.confirming
                ? 360
                : 420

                opacity:
                root.opened
                ? 1.0
                : 0.0

                scale:
                root.opened
                ? 1.0
                : 0.96

                color:
                root.confirming
                ? "#090707"
                : "#090909"

                border.width: 1

                border.color:
                root.confirming
                ? colors.red
                : "#292929"

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type:
                        Easing.OutCubic
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type:
                        Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 160
                        easing.type:
                        Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width:
                    root.confirming
                    ? 5
                    : 2

                    color:
                    root.confirming
                    ? colors.red
                    : "#242424"
                }

                // ====================================================
                // STANDARD COMMAND SCREEN
                // ====================================================

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 22
                        bottomMargin: 18
                        leftMargin: 24
                        rightMargin: 22
                    }

                    spacing: 0

                    visible:
                    !root.confirming

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: -2

                            Text {
                                text:
                                "NERV SYSTEM CONTROL"

                                color: "#D8D8D8"

                                font.family:
                                "monospace"

                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text:
                                "MAGI COMMAND INTERFACE"

                                color: "#5C5C5C"

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

                                text: "AUTH // 01"

                                color: "#555555"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                            }

                            Text {
                                anchors.right:
                                parent.right

                                text: "READY"

                                color: "#777777"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                                font.bold: true
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 14
                        Layout.bottomMargin: 14
                    }

                    Text {
                        text:
                        "SESSION TERMINATION CONTROL"

                        color: "#606060"

                        font.family:
                        "monospace"

                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.9
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 6

                        Repeater {
                            model: root.actions

                            Rectangle {
                                id: actionRow

                                required property int index
                                required property var modelData

                                Layout.fillWidth: true
                                height: 54

                                readonly property bool selected:
                                root.selectedIndex
                                === index

                                color:
                                selected
                                ? "#111111"
                                : "transparent"

                                border.width: 1

                                border.color:
                                selected
                                ? "#343434"
                                : "#222222"

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }

                                    width:
                                    actionRow.selected
                                    ? 3
                                    : 1

                                    color:
                                    actionRow.selected
                                    ? colors.red
                                    : "#252525"
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

                                    color:
                                    actionRow.selected
                                    ? colors.red
                                    : "#494949"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 7
                                    font.bold: true
                                }

                                Column {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 50
                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    spacing: 2

                                    Text {
                                        text:
                                        modelData.title

                                        color:
                                        actionRow.selected
                                        ? "#E0E0E0"
                                        : "#9B9B9B"

                                        font.family:
                                        "monospace"

                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Text {
                                        text:
                                        modelData.subtitle

                                        color: "#4D4D4D"

                                        font.family:
                                        "monospace"

                                        font.pixelSize: 6
                                    }
                                }

                                Text {
                                    anchors {
                                        right: parent.right
                                        rightMargin: 13
                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    visible:
                                    actionRow.selected

                                    text: ">"

                                    color: colors.red

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onEntered: {
                                        root.selectedIndex =
                                        actionRow.index
                                    }

                                    onClicked: {
                                        root.requestAction(
                                            actionRow.index
                                        )

                                        keyboardFocus
                                        .forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Divider {
                        Layout.bottomMargin: 11
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "↑↓ SELECT  //  ENTER EXECUTE"

                            color: "#4F4F4F"

                            font.family:
                            "monospace"

                            font.pixelSize: 6
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            "ESC CLOSE  //  1-4 DIRECT"

                            color: "#4F4F4F"

                            font.family:
                            "monospace"

                            font.pixelSize: 6
                        }
                    }
                }

                // ====================================================
                // EMERGENCY CONFIRMATION
                // ====================================================

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 24
                        bottomMargin: 20
                        leftMargin: 28
                        rightMargin: 26
                    }

                    spacing: 0

                    visible:
                    root.confirming

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            "EMERGENCY"

                            color: colors.red

                            font.family:
                            "monospace"

                            font.pixelSize: 17
                            font.bold: true
                            font.letterSpacing: 2.0
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            "AUTHORIZATION REQUIRED"

                            color: colors.red

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 12

                        height: 3
                        color: colors.red
                    }

                    Text {
                        Layout.topMargin: 21

                        text:
                        root.confirmIndex === 2
                        ? "REBOOT SYSTEM"
                        : "POWER OFF SYSTEM"

                        color: "#E2E2E2"

                        font.family:
                        "monospace"

                        font.pixelSize: 20
                        font.bold: true
                        font.letterSpacing: 1.0
                    }

                    Text {
                        Layout.topMargin: 5

                        text:
                        root.confirmIndex === 2
                        ? "PRIMARY SYSTEM WILL REINITIALIZE."
                        : "PRIMARY SYSTEM WILL TERMINATE."

                        color: "#646464"

                        font.family:
                        "monospace"

                        font.pixelSize: 8
                        font.letterSpacing: 0.5
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 58

                        color: "#110A0A"

                        border.width: 1
                        border.color: "#52201D"

                        RowLayout {
                            anchors.fill: parent

                            anchors {
                                leftMargin: 15
                                rightMargin: 15
                            }

                            Text {
                                text:
                                "MAGI DECISION"

                                color: "#757575"

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text:
                                "MELCHIOR"

                                color: colors.red

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                            }

                            Text {
                                text:
                                "BALTHASAR"

                                color: colors.red

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                            }

                            Text {
                                text:
                                "CASPER"

                                color: colors.red

                                font.family:
                                "monospace"

                                font.pixelSize: 7
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 14

                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true

                            height: 42

                            color:
                            confirmMouse.containsMouse
                            ? colors.red
                            : "#130B0B"

                            border.width: 1
                            border.color: colors.red

                            Text {
                                anchors.centerIn: parent

                                text:
                                "[ Y / ENTER ] EXECUTE"

                                color:
                                confirmMouse.containsMouse
                                ? "#090909"
                                : colors.red

                                font.family:
                                "monospace"

                                font.pixelSize: 8
                                font.bold: true
                            }

                            MouseArea {
                                id: confirmMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    root.executeConfirmed()
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true

                            height: 42

                            color:
                            cancelMouse.containsMouse
                            ? "#151515"
                            : "transparent"

                            border.width: 1
                            border.color: "#323232"

                            Text {
                                anchors.centerIn: parent

                                text:
                                "[ N / ESC ] ABORT"

                                color: "#888888"

                                font.family:
                                "monospace"

                                font.pixelSize: 8
                                font.bold: true
                            }

                            MouseArea {
                                id: cancelMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    root.cancelConfirmation()

                                    keyboardFocus
                                    .forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }

            // ====================================================
            // KEYBOARD
            // ====================================================

            FocusScope {
                id: keyboardFocus

                anchors.fill: parent
                focus: true

                Keys.onPressed:
                function(event) {
                    if (!root.opened)
                        return

                        if (root.confirming) {
                            if (
                                event.key === Qt.Key_Y
                                || event.key
                                === Qt.Key_Return
                                || event.key
                                === Qt.Key_Enter
                            ) {
                                root.executeConfirmed()
                                event.accepted = true
                                return
                            }

                            if (
                                event.key === Qt.Key_N
                                || event.key
                                === Qt.Key_Escape
                            ) {
                                root.cancelConfirmation()
                                keyboardFocus
                                .forceActiveFocus()

                                event.accepted = true
                                return
                            }

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Up
                        ) {
                            root.moveSelection(-1)

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Down
                        ) {
                            root.moveSelection(1)

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Return
                            || event.key
                            === Qt.Key_Enter
                        ) {
                            root.requestAction(
                                root.selectedIndex
                            )

                            keyboardFocus
                            .forceActiveFocus()

                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_1) {
                            root.requestAction(0)
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

                            keyboardFocus
                            .forceActiveFocus()

                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_4) {
                            root.requestAction(3)

                            keyboardFocus
                            .forceActiveFocus()

                            event.accepted = true
                            return
                        }

                        if (
                            event.key
                            === Qt.Key_Escape
                        ) {
                            root.closeMenu()
                            event.accepted = true
                        }
                }

                Component.onCompleted: {
                    forceActiveFocus()
                }
            }
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1
        color: "#242424"
    }
}
