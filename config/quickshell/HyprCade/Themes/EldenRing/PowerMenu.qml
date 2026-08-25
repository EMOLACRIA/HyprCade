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

    Palette { id: colors }

    readonly property var actions: [
        { number: "I", title: "SEAL THE GRACE", sub: "LOCK SESSION", hint: "Let this place fall silent." },
        { number: "II", title: "LEAVE THE LANDS", sub: "LOG OUT", hint: "Depart from this session." },
        { number: "III", title: "REKINDLE THE WORLD", sub: "REBOOT", hint: "Begin the cycle anew." },
        { number: "IV", title: "EXTINGUISH GRACE", sub: "POWER OFF", hint: "Let the machine rest." }
    ]

    function accentFor(index): color {
        if (index === 0) return colors.blue
        if (index === 1) return colors.text
        if (index === 2) return colors.yellow
        if (index === 3) return colors.red
        return colors.text
    }

    function openMenu(): void {
        hideTimer.stop()
        selectedIndex = 0
        confirming = false
        confirmIndex = -1
        windowVisible = true
        opened = true
    }

    function closeMenu(): void {
        opened = false
        confirming = false
        confirmIndex = -1
        hideTimer.restart()
    }

    function toggleMenu(): void {
        if (opened) closeMenu()
        else openMenu()
    }

    function requestAction(index): void {
        selectedIndex = index

        if (index === 0) {
            closeMenu()
            Quickshell.execDetached(["sh", "-lc", "sleep 0.45; exec hyprlock"])
            return
        }

        if (index === 1) {
            closeMenu()
            Quickshell.execDetached(["uwsm", "stop"])
            return
        }

        confirmIndex = index
        confirming = true
    }

    function executeConfirmed(): void {
        if (!confirming) return
        const index = confirmIndex
        confirming = false

        if (index === 2) {
            Quickshell.execDetached(["systemctl", "reboot"])
            return
        }

        if (index === 3)
            Quickshell.execDetached(["systemctl", "poweroff"])
    }

    function cancelConfirmation(): void {
        confirming = false
        confirmIndex = -1
    }

    function moveSelection(delta): void {
        if (confirming) return
        let next = selectedIndex + delta
        if (next < 0) next = actions.length - 1
        if (next >= actions.length) next = 0
        selectedIndex = next
    }

    Timer {
        id: hideTimer
        interval: 180
        onTriggered: if (!root.opened) root.windowVisible = false
    }

    IpcHandler {
        target: "powermenu"
        function toggle(): void { root.toggleMenu() }
        function open(): void { root.openMenu() }
        function close(): void { root.closeMenu() }
    }

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

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(
                    colors.background.r,
                    colors.background.g,
                    colors.background.b,
                    root.opened ? 0.82 : 0.0
                )

                Behavior on color { ColorAnimation { duration: 160 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (!root.confirming) root.closeMenu()
                }
            }

            Rectangle {
                id: menuFrame
                anchors.centerIn: parent
                width: 560
                height: root.confirming ? 488 : 442
                opacity: root.opened ? 1 : 0
                scale: root.opened ? 1 : 0.97
                color: colors.background
                border.width: 1
                border.color: root.confirming
                    ? root.accentFor(root.confirmIndex)
                    : colors.border

                Behavior on opacity { NumberAnimation { duration: 160 } }
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
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
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 118
                    height: 1
                    color: colors.yellow
                    opacity: 0.65
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.topMargin: 26
                    anchors.bottomMargin: 22
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 2

                            Text {
                                text: "THE LANDS BETWEEN"
                                color: colors.yellow
                                font.family: "serif"
                                font.pixelSize: 15
                                font.bold: true
                                font.letterSpacing: 1.5
                            }

                            Text {
                                text: root.confirming
                                    ? "A DECISION AWAITS"
                                    : "SITE OF GRACE  //  COMMANDS"
                                color: colors.muted
                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.8
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Column {
                            spacing: 0

                            Text {
                                anchors.right: parent.right
                                text: "✦"
                                color: root.confirming
                                    ? root.accentFor(root.confirmIndex)
                                    : colors.yellow
                                font.family: "serif"
                                font.pixelSize: 22
                            }

                            Text {
                                anchors.right: parent.right
                                text: root.confirming
                                    ? "CONFIRM THY WILL"
                                    : "GUIDED BY GRACE"
                                color: colors.muted
                                font.family: "serif"
                                font.pixelSize: 7
                            }
                        }
                    }

                    Text {
                        Layout.topMargin: 10
                        text: root.confirming
                            ? "The path before thee cannot be taken lightly."
                            : "Choose how this journey shall continue."
                        color: colors.text
                        font.family: "serif"
                        font.pixelSize: 9
                        font.italic: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 15
                        Layout.bottomMargin: 14
                        height: 1
                        color: colors.border
                    }

                    Text {
                        text: root.confirming ? "PENDING CHOICE" : "ACTIONS"
                        color: root.confirming
                            ? root.accentFor(root.confirmIndex)
                            : colors.yellow
                        font.family: "serif"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 7

                        Repeater {
                            model: root.actions

                            Rectangle {
                                id: actionEntry
                                required property int index
                                required property var modelData

                                width: parent.width
                                height: 58
                                visible: !root.confirming || index === root.confirmIndex
                                color: root.selectedIndex === index
                                    ? colors.panelAlt
                                    : "transparent"
                                border.width: 1
                                border.color: root.selectedIndex === index
                                    ? root.accentFor(index)
                                    : colors.border

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.number
                                    color: root.selectedIndex === index
                                        ? root.accentFor(index)
                                        : colors.muted
                                    font.family: "serif"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 44
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: modelData.title
                                        color: root.selectedIndex === index
                                            ? root.accentFor(index)
                                            : colors.text
                                        font.family: "serif"
                                        font.pixelSize: 11
                                        font.bold: root.selectedIndex === index
                                        font.letterSpacing: 0.6
                                    }

                                    Text {
                                        text: modelData.hint
                                        color: colors.muted
                                        font.family: "serif"
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.sub
                                    color: colors.muted
                                    font.family: "serif"
                                    font.pixelSize: 8
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        if (!root.confirming)
                                            root.selectedIndex = actionEntry.index
                                    }

                                    onClicked: {
                                        if (!root.confirming) {
                                            root.requestAction(actionEntry.index)
                                            keyHandler.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 14
                        height: root.confirming ? 72 : 0
                        visible: root.confirming
                        color: colors.panel
                        border.width: 1
                        border.color: root.accentFor(root.confirmIndex)

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.confirmIndex === 2
                                    ? "REKINDLE THE WORLD?"
                                    : "EXTINGUISH GRACE?"
                                color: root.accentFor(root.confirmIndex)
                                font.family: "serif"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "[ Y / ENTER ]  ACCEPT        [ N / ESC ]  RETURN"
                                color: colors.text
                                font.family: "serif"
                                font.pixelSize: 8
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 11
                        height: 1
                        color: colors.border
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: root.confirming
                                ? "THY WILL  //  PENDING"
                                : "↑↓ CHOOSE  //  ENTER ACCEPT"
                            color: root.confirming
                                ? root.accentFor(root.confirmIndex)
                                : colors.muted
                            font.family: "serif"
                            font.pixelSize: 8
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.confirming
                                ? "ESC  //  RETURN"
                                : "1–4  //  DIRECT PATH"
                            color: colors.muted
                            font.family: "serif"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            FocusScope {
                id: keyHandler
                anchors.fill: parent
                focus: true

                Keys.onPressed: function(event) {
                    if (!root.opened)
                        return

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
                            keyHandler.forceActiveFocus()
                            event.accepted = true
                            return
                        }

                        event.accepted = true
                        return
                    }

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

            Component.onCompleted: keyHandler.forceActiveFocus()
        }
    }
}
